# G1 — Source A work-action pilot (minimal asset packet, ART PENDING)

**17/10/2026 · PR #20 stacked draft · Godot 4.7.2 · target 1280×720.** This is an **asset-proof packet only**. It does not authorize fabricated assets, new gameplay/animation clock, copying unverified binaries, CI, FULL or merge.

## 1. Verified repo audit (read from exact Source A binaries metadata)

All **three** current verified baked character rigs have **only `stand` and `walk`** in both `godot/assets/actors/<id>/asset.json` (`clips[].name`) and `animations.tres` SpriteFrames:

| Rig | Sex proven by prior actual artwork inspection | Repo clips | Missing |
| --- | --- | --- | --- |
| `1113028_1` | Female | `stand`, `walk` | `mining`, `chopping`, `planting` |
| `body_1110201` | Male | `stand`, `walk` | `mining`, `chopping`, `planting` |
| `body_1120402` | Male | `stand`, `walk` | `mining`, `chopping`, `planting` |

Current `ModularDiscipleActor` chooses an *actually present* action animation if provided, otherwise `stand`; the displayed map job/progress cue is **not an animated dig/chop/plant action**. No real action clip has been imported or visually tested. This explains the owner's “đi mỏ nhưng không thấy đào” feedback despite production jobs working.

## 2. Smallest feasible verified-asset task (future separately authorized art work)

1. Work with the owner's **already existing** Batch-01 conversion output at `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472` and the original accessible, licensed Source A Spine sources. Inspect the *actual animation names* / captured playback for `1113028_1`, `body_1110201`, `body_1120402`; never infer action presence from filenames or game concepts. Do not rerun/rebake all 10 rigs.
2. Prefer a **single male rig + single female rig** as pilot, reusing rig across disciples by sex/cosmetic seed. For each, search for authored action compatible with mining/chopping/planting; require actually animated hands/tool/contact/feet. If genuinely absent, report `SOURCE_A_AUTHORED_ACTION_NOT_FOUND` with precise rig and animation inventory. **Do not relabel stand/walk as digging or invent the clip.**
3. Only if authentic action frames exist, export at the converter's already verified settings, preserve the same frame registration/foot anchor and cropping/scale, add to `animations.tres` and update `asset.json` `file_sha256` based on actual bytes; preserve provenance manifest and original atlas. Check SHA256 for every listed binary; run only one pilot renderer check. If output/manifest cannot be safely updated, do not integrate.
4. When valid, visually map action to `ModularDiscipleActor` **only when the corresponding real saved job/plot exists**, with left/right facing/mirror; vertical movement still uses the same horizontal artwork. Existing `stand/walk` fallback continues for rigs missing verified action. Do not alter `SimulationScheduler`, work duration, receipt timing, resource amounts, paths or SaveService.
5. Acceptance: one native 1280×720 screenshot/video with a selected Mine worker showing actual action and worksite progress, another for Linh Lâm / Linh Điền if real clips were found, plus focused play/sex/seed/loop tests. **Android and owner visual signoff remain PENDING** until performed.

**IMPORTANT:** Source A Batch-01 converted technical PASS does **not** prove source contains mining/forest/planting animations. Existing Windows user has these binaries locally; avoid requesting mass asset reuploads. If no verified original action exists, plan a **separate explicitly authored artwork job**, identified honestly as *new art*, not Source A extraction. Do not create that artwork within this packet.

## 3. Immediate current implementation

PR #20 presentation already has a small per-instance `SectProductionWorksiteCue` with saved scheduler progress, planned output and settlement-only `+N đã vào kho`. The actual digging motion is **separate missing art debt**, not a reason to create fake yield or add carry-cycle simulation. G1 owner visual acceptance stays **OPEN**.
