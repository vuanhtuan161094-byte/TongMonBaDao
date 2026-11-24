# BATCH 6 — Kiếm Tu Nhân · VFX source-only, OWNER APPROVED (2026-11-24)

Owner asked to **produce by batches**, not stop for approval at every cel. This handoff records six *complete 24-frame source-only animations, now owner-approved as the current visual baseline* in the conversation-delivered ZIP `TMB_BATCH_6_VFX_NHAN_APPROVED_SOURCE_20261124.zip`. The ZIP includes 144 transparent 512×512 PNG cels, six 2048×3072 RGBA atlases, six 25 FPS / 0.96 s 1× GIF previews, batch overview GIF/MP4, exact file hashes, and two local builder scripts.

The actual binary ZIP and PNGs are **not staged in GitHub by this commit**; consequently the GitHub check cannot honestly claim exact-SHA binary asset QA. Each per-frame SHA lives in the separately delivered ZIP, and the atlas SHA values here are the local hashes for later transfer verification.

| Skill (Human) | Gameplay shape / target limit | Atlas SHA-256 (local) |
|---|---|---|
| Tứ Phương Phi Nhận | line / 3 | `7f88e652d84e31ce3e746a366fd564e4fcf45dbba16e228a24f66e2ce3306175` |
| Kiếm Quang Hồi Chủ | single_target / 1 | `86f07ed5789370dc5aacbb9d201fc1d39bbd9b3ceeb73307f1d6ee252b33e42d` |
| Vạn Kiếm Quy Tông | circle / 3 | `23a5906585fdc973b35c740c4a1aa2feb339ebdb19ce871cf2d131885024ff35` |
| Trảm Ảnh Nhất Tuyến | single_target / 1 | `52cab7a39f446614eb1b297bc3a2c980905dc0c302a053214f3c424009c509f8` |
| Phá Vân Trực Trảm | line / 3 | `5401e9a93d2b32e910f07bd4afc5b4703c408e251e756343e2a283b6b8d672bc` |
| Đoạn Thủy Kiếm Mang | single_target / 1 | `61eeecd743ca07de7d866fe9316fb0237115951ca9e08b746951ed4a6f25bb4a` |

**Local QA completed:** 6×24/24 PNG RGBA valid, distinct frame SHA in each skill, 8px empty border, every frame pixel-identical to its atlas cell, six source GIFs each 24 frames at 25 FPS; source preview background comparisons 174px. No source material was extracted from a marketing poster. Sources were independently AI-painted VFX-only art and reused with **disclosed transformations**; not every derived cel is a separate AI generation, and the five follow-up skills reuse related source art motifs.

**Visual caveat:** Owner accepted all six source animations as the current baseline on 2026-11-24. Several remain faint at true 1× and reuse sword motifs; approval does NOT certify JX-quality runtime or remove the possibility of later aesthetic refinement. Improving independent silhouette/weapon design is the next art task. Do NOT report six full game skills, JX quality achieved, or runtime QA based on these technical checks.

**Strict gates:** SOURCE ART OWNER=APPROVED (batch 6); G3 binary CI in repository=NOT_EXECUTED; source binary in repo=NOT_STAGED; Godot/Chromium=NOT_EXECUTED; PvE=HOLD; PR #72 DRAFT; no Codex Cloud, no rig, no merge, do not modify SaveService/combat logic.

The already provisionally accepted Kiếm Vũ Hồi Phong R1E V2 remains immutable. Tứ Phương Phi Nhận's existing G3 gate remains SOURCE_PENDING at the GitHub binary level until verified transfer. This metadata commit does not trigger PvE integration or runtime changes.

## Source-art approval record (2026-11-24)

User approved the SIX 24-frame source GIFs together: **“Ok. Chốt đi.”** This freezes their version as the current accepted source-art baseline. Local approved ZIP SHA-256: `6efe7d6938dc383582b308dc0b14715564724af0f6cd7aad1661002f5effa2e9`, original unmodified ZIP SHA-256: `ef7e5842bb69853404f23fc3284134a14ba2431b84e925694f739eb9f03cbda6`. The approved ZIP includes `OWNER_APPROVAL_RECORD.json` and source-preserving status updates. **Actual binary files are not in GitHub**; the PR records approval metadata only.

Independent local byte-level recheck: 144 RGBA 512×512 source frames, 8px clean borders, 24 unique PNG hashes per skill, pixel-identical alignment with 6 atlases 2048×3072, six 24-frame source GIFs. No art was silently altered during approval. Next release stage: transfer approved exact-SHA bytes into the PR, run GitHub CI on those bytes, then isolate Godot/Chromium lab testing; PvE remains HOLD and merge not authorized.
