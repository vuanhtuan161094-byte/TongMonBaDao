# POI11 Vạn Độc Xuyên Tâm R7 — native Godot technical and manual review (2026-11-16)

**Repository:** `vuanhtuan161094-byte/TongMonBaDao`, existing PR #72 Draft, branch `integration/pve-p0-playable-ui-20261103`.  
**Full source/test/evidence QA commit:** `8b5cc1d7d65672141c1939fb1e0ce109cd42e55e` (script R7 introduced at `72317bbda75d4d354176459aba95b3a3797f854a`, new focused tests `2e8956acf913de76b206492ede635bb3e96a1303`, packet `6dd9aaaae494dffed682eaecbb1a7753259ec9b3`). This document is an evidence record only, not a new engine run or gameplay change.

## Exact technical proof

- Godot 4.7.2 stable official, GL Compatibility on Linux llvmpipe; [official run #43834720709](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43834720709) **SUCCESS** on exact SHA `8b5cc1d7d65672141c1939fb1e0ce109cd42e55e`, [artifact #14209989505](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43834720709/artifacts/14209989505).
- V4 packet/assets/evidence validator passed, strict import and GDScript parse PASS, focused `VFX_POI11_R1_RESULT=PASS failures=0`. Scene is still in legacy path `godot/labs/combat_lab/poison11/r1_original/` but its artwork and code are **revision R7**, not the original R1.
- G3.5: genuine 160-frame 1280×720 Godot mini movie with actual charge 0.55s, peak 2.10s and three WALK-monster moving contact 2.43s captures. Full native 660-frame **11.00-second** movie, encoded at fixed 60 fps, plus GIF and **14 genuine native checkpoint frames**.
- Full media SHA256 verified independently from the downloaded GitHub Actions ZIP: **16/16 match**. Movie `POI11-R1-full.mp4` **ce9914e4b110517c7492373cdfd221faf7a5a555bceb1565f18b020733b24cf0**; GIF `POI11-R1-full.gif` **eb6b160bc1bf11a98e9d810dc6aea481bae30c16b3d5eb71919747e9e18a81c2**. The ZIP's `FULL-SHA256.txt` contains individual hashes for all 14 stills. Artifact retention is not permanent; durable original masters, atlas generator, sprites, scene/test and this exact SHA survive.
- Four independent painted original attack atlas resources: **10 charge + 10 flight + 10 purple/jade vortex + 8 contact = 38 poses**, total raw RGBA8 **7,421,952 bytes** (7.08 MiB); excludes other game effects and actor textures. First-party source provenance in `docs/operations/vfx_packets/POI11_R1_V4_PREFLIGHT.json`; no JX/VL commercial art pixels copied. Unique hash/frame count is NOT a substitute for artistic motion QA.

## Actual native 1× movie review, 14+ phase inspections

- `0.20, 0.55, 0.98`: visible caster-side luminous spear charge; `1.24, 1.55, 1.84`: independent painted needle/spear takes one continuous cosmetic path with restrained following echo.
- `1.86–2.02`: continuous R7 transition; a previous R6 frame gap immediately before the expanding crown is no longer present. One spear fades as the painted purple/jade vortex enters behind three moving actors; no extra gameplay projectile is fabricated.
- `2.10, 2.22, 2.43, 2.71`: irregular circular burst and three brief independent torso-anchored contact glints; monsters' motion and above-head status anchors follow the same three WALK actors. Faces remain visually recognizable; some vortex crowding persists, for owner art judgement.
- `2.72, 2.78, 2.84, 2.90, 2.96, 3.02, 3.08, 3.16`: separately inspected smooth taper/fade. Large attack burst is gone by 3.08–3.16s, with no square source-crop boundary observed.
- `3.13, 5.50, 8.50, 10.60`: one small shared poison badge per simulated affected actor, never a giant continuous body aura; after eight mock-status seconds all three badges are gone by 10.60s.

**Visual self review:** R7 native motion is suitable for owner review. G3.5 subscore: silhouette **4/5**, material/pure light **4/5**, charge→release→peak timing **4/5**, contact/readability **4/5**, distinct poison identity **4/5**, fade **4/5**. These are subjective self-QA, **NOT owner acceptance**. Remaining aesthetic risk: busy central vortex/contact overlap at crowded gameplay scale; moving LAB uses three dummies, not real world PvE target events or 6v8/30×40 stress.

## Distinct three-clock and release gates

- **Catalogue:** `tmb.skill.poison.doc_cham.ultimate.human`, `poison/nether/circle`, radius 3, cap 3, range 8, cast 1.15s, cooldown 36s, projectile speed 8, status duration 8s, 2 poison stacks. Actual `hit_count` absent/UNSPECIFIED; no inferred receipt.
- **Local isolated VFX clock:** charge 0–1.15, one cosmetic painted spear 1.15–2.07 taper, irregular area opens 1.82–3.08, three **synthetic visual-only** contact times 2.20/2.28/2.36; one shared small status badge for simulated remaining time.
- **Showcase clock:** 11-second fixed-fps LAB loop and status demonstration; no implied world-to-screen projectile travel time or combat event.
- **Hard statuses:** `GODOT_V4_TECHNICAL_PASS / ART_SELF_REVIEW_PASS_FOR_OWNER_DECISION / OWNER_VISUAL_PENDING / RUNTIME_MAPPING_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_WINDOWS_ANDROID_QA_PENDING`. Native encoded 60fps or CI CPU/GPU time is NOT real Android or Windows hardware FPS.
- No rig, no Codex, no branch/merge, no Combat V2, SaveService, economy, damage, targeting, real status or PvE activation. Preserve earlier owner-approved Poison skills and R6 test artifact for source comparison.

**Next gate:** Owner watches actual R7 11-second Godot movie. Only explicit approval may change `OWNER_VISUAL_PENDING`; live Combat V2 hookup and device/load tests still need separate authorization.
