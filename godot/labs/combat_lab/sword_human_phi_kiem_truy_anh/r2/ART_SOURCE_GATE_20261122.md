# Phi Kiếm Truy Ảnh · Ngự Kiếm · Nhân — R2 G0–G3 art-source checkpoint (2026-11-22)

> **NO ART PASS / NO NATIVE RUN / NO WEB DEPLOY / NO PVE.**
> Scoped VFX research/art preflight only. This does not replace Art-First Production System V4, or supersede earlier R1 owner rejection. Neither R1 nor this R2 has been approved as production artwork.

## 1. Provenance / exact canonical contract (G0)

- Repository: `vuanhtuan161094-byte/TongMonBaDao`; Draft PR #72; branch `integration/pve-p0-playable-ui-20261103`.
- Inspected source baseline HEAD: `b191ef6887fac44c7922c81936a3c7c2d7cd526d`; live HEAD before writing moved to `445e386faae389193ed5e593e2c2a076fc922efc` (independent Source A disciple-retirement changes; no overlap with this school-specific packet).
- Canonical JSON: `godot/data/combat/v63_sword_combat_catalog.json`; ledger: `docs/operations/vfx_school_ledgers/03_sword_183.csv`.
- Human skill ID: `tmb.skill.sword.ngu_kiem.active_01.human`; `Phi Kiếm Truy Ảnh`; `sword / ngu_kiem / active_01 / human`.
- Declared: `damage`, element `metal`, `single_target`, `target_limit=1`, `range=8`, `cast_time=0.28s`, `cooldown=8s`, `projectile_speed=10`, `duration=0`; `damage_ratio=1.35` (canonical candidate, NOT art-driven balance).
- Canonical status: `CANDIDATE_GATED_SOURCE_PENDING`, `enabled=false`, no PvE integration.
- Sword source actor bridge: `godot/labs/visual_bridge_v1/as48_sword_anchor_lab.gd`; existing AS48 FRONT ONLY authored attack (4 cels / 7fps), real monster WALK; no other directions confirmed by this packet. Existing R1 code-painted FX source and TECH_CUE_ONLY Web entry remain unchanged and owner-rejected.

### The three separate clocks

| Clock | Source authority | Moment/timing | Meaning |
| --- | --- | --- | --- |
| Combat | Catalogue | cast 0.28s, CD 8s, speed 10 **world-unit mapping pending** | Canonical, no game-value edits |
| Combat receipt | Runtime/event | hit and release exact receipt **RUNTIME_MAPPING_PENDING** | No invented LAB hit or extra damage |
| Visual-only R2 | G2 candidate | charge → release → one sword-shaped flight → one contact → fade | Presentation only; all local timings **NOT FINAL** pending anchor and moving-target checks |
| QA/showcase | Local authoring | **NOT_EXECUTED** | No native/movie timeline has been claimed |

## 2. G1 rights-aware references

- Internal owner-preferred technique/art-quality comparison: POI06 R11 (translucent movement); POI19 R3 (continuous animated light), POI15 R1B (readable contact). These are benchmarks, not source pixels for sword art.
- External Kiếm Thế / JX / Võ Lâm in-game VFX imagery studied at the *still/reference level* on 22/11. Observed: short intense blue-white focal action and visible actor/contact hierarchy; footage/complete timecoded animation **not independently examined for this packet**. No third-party pixels included.
- Source from the R2 local illustration is first-party generated in this ChatGPT session. No JX asset import or third-party production license assumption.

## 3. G2 original motion direction and semantics

- Identity: a single sharp silver-blue sword-qi body detached from actual AS48 sword tip at the real cast release; no fake multiple swords, hits or homing.
- Intended pose progression (8 distinct illustrative poses): (1) narrow gathering; (2) irregular energy tightening; (3) blade release; (4–5) pointed one-projectile flight; (6) white-hot local contact; (7) separated light splinters; (8) residual fade.
- Layers desired: irregular blue/silver translucent MIX material; very small near-white core and compact selective ADD at contact; restrained low-opacity halo behind actor; separate target contact/residue, no giant neon loops.
- Anchor: AS48 actual sword tip via existing read-only frame V9.3 bridge; contact follows *actual moving monster* in isolated LAB; target receipt mapping remains runtime pending.
- No skeletal rig. No changes to actor source, weapon source, gameplay, Combat V2, SaveService, AI, economy or global VFX catalog.

## 4. G3 original source **attempt** and honest preflight STOP

One first-party image-generated 4×2 transparent illustrated source sheet was created in the ChatGPT session, 1774×887 RGBA. Source SHA-256:
`2ba61b613d9351379069bf1b3faac630d98db323e74128006e76fa7975d70ce0`.

A **local-only, NOT REPOSITORY-COMMITTED** 8-pose extraction was prepared as 2048×1024 atlas / eight 512×512 RGBA poses and inspected at reduced approximate in-game 1× over dark and light backgrounds. The extracted preview is a diagnostic; alpha edge tapering was applied to keep source spill from neighboring cells. Original and extracted image bytes are **not** in this GitHub commit; their SHA is provenance, not proof that GitHub holds the source.

**G3 ART SELF RESULT: `G3_SOURCE_REWORK_REQUIRED` — HARD STOP.** Failure reasons:
1. Original generated poses spill across sprite-sheet cell boundaries; clipping/tapering obscures the authored per-pose envelope.
2. On light beige background the blue-white/silver source loses substantial contrast.
3. Shape currently resembles a luminous spear/bolt rather than a clearly differentiated sword-qi profile, especially in flight.
4. No actor+monster actual-scale overlay from GitHub verified for this candidate and no independent G3 accepted master stored durably on PR #72.

Do **NOT** treat atlas-extracted frame-count/alpha/hashes as art acceptance. Do not attach R2 to `/vfx/`, alias Tiên/Thần to R2, build native Godot or run G4–G7 until the **actual illustrated RGBA source has been repaired, committed and visually self-passed**.


### Recoverable exact bytes (not GitHub asset upload)

To avoid losing the original first-party RGBA when this chat closes, the exact 1774×887 image, extracted eight 512² pose PNGs, 2048×1024 atlas, dark/light diagnostic preview, local Python extraction code, and SHA manifest have been uploaded by ChatGPT to **ChatGPT Library**:

- Library path: `/TMB-VFX/SWORD/TMB_SWORD_PHI_KIEM_HUMAN_R2_SOURCE_CANDIDATE_FULL.zip`
- Library ID: `libfile_cbcb5e52a74c8191b68dc45ad2504e71`
- Exact archive SHA-256: `0b0ece797ff2219882a077ec9ab81cd03688e6ce03d810db8559939028e358b8`.
- **This is a recoverable Library source, not binary content committed into GitHub**. The Art-G3 hard STOP remains in effect. Only move an edited, visually improved final art source into the repository after fresh HEAD and one-writer check.

## 5. Tier fallback semantic check (proposal only)

This Human family has four descendant IDs in the same catalogue: `immortal.a`, `immortal.b`, `divine.a`, `divine.b`. All are `damage / single_target / target_limit=1 / element=metal`, but differ in cast/cooldown/projectile speed/range/damage ratio. A future **read-only visual-only alias** may be semantically possible if the new Human art is approved as a valid source and tier-specific timing follows actual receipts. **No alias is created now**; `VISUAL_SOURCE_PENDING` for every descendant. Neither artwork nor PvE is approved.

## 6. Gates and continuation

| Gate | Status |
| --- | --- |
| G0 | Canonical source data checked |
| G1 | Still references; full motion not verified |
| G2 | Proposed original eight-stage choreography |
| G3 | **SELF_REWORK_REQUIRED; master not permanently committed** |
| G3.5–G3.7 | **NOT_EXECUTED** |
| G4–G7 / CI | **NOT_EXECUTED** for R2 |
| Owner | **OWNER_PENDING** for R2 (R1 owner-rejected) |
| Web / browser actor+monster pixel gate | **NOT_EXECUTED** for R2 |
| Tiên/Thần fallback | **VISUAL_SOURCE_PENDING**, no mapping |
| G8 PvE + physical device | **HOLD** |

**Next SINGLE action:** paint/re-generate a clean transparent original **sword-specific** 8-phase source with independent silhouettes, strong bright-terrain contrast and distinct non-touching cells; preserve artist source on PR #72, compare at 1× with actual AS48 and WALK monster, then only if G3 SELF PASS add Godot G3.5 native and use the existing single `/vfx/` reviewer. Protect POI06/19/15, HF02 and FIST14 R11.
