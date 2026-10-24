# PR #28 — Worker Source A asset comparison

Date: 2026-10-24  
Repository: `vuanhtuan161094-byte/TongMonBaDao`  
Branch: `ui/pr27-runtime-readability-20261024`  
Code commit: `47b704270ae165504aeef526963e8d03f87bc579`

## Scope and result

Scanned the local worker output root `E:\codex\2026-10-21\t-ng-m-n-b-o-2\outputs\pilot_assets`, its V5 review copies, the converted-asset QA folders, and the PR #28 actor library. Four worker actor packs were found. They are verified and are already present in PR #28 in content-equivalent form. No new binary pack was copied or used to overwrite the existing library.

The worker exports and PR #28 text resources have different **raw** SHA-256 values because the worker exports use CRLF and the PR #28 resources use LF. After newline normalization, every `actor.tscn` and `animations.tres` file compares exactly. Each atlas page has an exact raw SHA-256 match. This distinction is recorded in `WORKER_ASSET_CATALOG.json`; raw hashes were not rewritten to imply equality.

| Worker pack | Clips and authored frames | Atlas pages | Godot/native QA samples | PR #28 comparison | Integration decision |
| --- | --- | ---: | ---: | --- | --- |
| `v5_sa_boss_410041_1` | stand 60, run 28, attack1 30, hit 15, dead 30 (154 unique stored frames) | 5 | 15/15 RGBA and alpha exact | Normalized scene/clip text exact; all five atlas SHA exact | Reuse existing Boss-slot visual only. Never imply a live CARE Boss event. |
| `v5_sa_female_1113028_1` | attack1 29, hit 15, dead 15 (59 frames); no stand/walk clip | 2 | 9/9 RGBA and alpha exact | Normalized scene/clip text exact; both atlas SHA exact | Reuse existing female combat actor. Do not invent locomotion clips. |
| `v5_sa_male_body_1110201` | stand 48, walk 24, attack1 29, hit 15, dead 15 (131 frames) | 3 | 15/15 RGBA and alpha exact | Normalized scene/clip text exact; all three atlas SHA exact | Reuse existing male combat actor. |
| `v5_sa_monster_1113031_1` | stand 60, walk 24, attack1 29, hit 10, dead 22 (145 frames) | 3 | 15/15 RGBA and alpha exact | Normalized scene/clip text exact; all three atlas SHA exact | Reuse only for the canonical `thanh_lang` species through the existing CARE visual adapter. |

All packs declare 30 FPS, 768×768 frame canvas, foot anchor `(384, 540)`, and one authored facing. No additional directional set is claimed. The source `.skel`, `.atlas`, and texture provenance hashes, exported raw hashes, and per-asset QA paths are in the JSON catalog.

## Runtime mapping already present in P3.2

- `DiscipleSourceAVisualPool` and `DiscipleActorVisualCatalog` select existing real V2 map/profile actors.
- `b3_care_combat_v5_presenter.gd` remains a read-only visual adapter for CARE/Combat V2. The real female or male disciple and the canonical Thanh Lang visual route are covered by `b3_care_combat_v5_presenter_test`.
- Boss-slot content is catalogued as display-only. The live adapter has no Boss event mapping (`boss_event_mapped=false`).
- The existing 32 MAP25 assets remain governed by their SHA-gated manifest; the focused artifact gate reports `accepted=32 missing=0 rejected=0`.

## Building-art candidates

The candidate manifest has 13 proposed building identities. Three have only 1/3 or 1/4 matching dependencies and remain `CANDIDATE_NEEDS_QA`; seven have no complete binary pack and remain `MISSING`; three are inferred visual analogs and remain `REJECTED`. In particular, no full Source A Mỏ, Linh Lâm, or Linh Điền pack was found. These incomplete candidates were not installed into P3.2. The current Source A map/buildings remain the accepted MAP25 art already in the scene.

The four contact sheets under `evidence/PR28/worker_assets/` are visual references from actual QA frames. Matching per-pack `frame_samples_compare.json`, `metrics.json`, `verification.json`, Godot 4.7.2 import/visual logs, and status files are bundled in `evidence/PR28/worker_assets/worker_asset_qa_47b70427.zip`. These are evidence, not gameplay mockups, and were not imported as game assets.

