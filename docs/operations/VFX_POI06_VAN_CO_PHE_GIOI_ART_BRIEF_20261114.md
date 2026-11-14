# VFX POI06 — VẠN CỔ PHỆ GIỚI / THE ABYSS OF TEN THOUSAND GU
Owner art-first VFX review | 2026-11-14 | PR #72 Draft | Godot 4.7.2 Compatibility 1280×720

## Exact source contract (verified on current branch)
- `tmb.skill.poison.co_doc.ultimate.human` — Độc Tu / Cổ Độc, tuyệt kỹ Human.
- `effect=poison`, `shape=circle`, `radius=3.0`, `target_limit=3`, `range=8.0`, `cast_time=1.10`, `cooldown=38`, `duration=8.0`, `poison_stacks=2` in `godot/data/combat/v63_human_combat_catalog.json`.
- These are read-only metadata constants. Combat V2 decides real skill selection, targets, poison status, HP/damage, cooldown, on-hit events. The isolated art LAB renders only 3 illustrative actors: it does NOT create 2 fake poison ticks or any real gameplay hit.

## Formal owner feedback POI05 and quality gap
- **Tán Cổ Diễn Nhiễm R10 is TEMPORARILY ACCEPTABLE ONLY**; owner explicitly says charge phase unappealing and the centipede ugly, although the skill may be left as-is to proceed. Record `PROVISIONAL_WORKFLOW_ACCEPTANCE`, but keep ledger `OWNER_VISUAL_PENDING`, `CHARGE_RING_POLISH_BACKLOG` and `CREATURE_ART_POLISH_BACKLOG`. Do NOT mark it final owner-approved.
- Approved Xà Ảnh uses a high-quality painted serpentine sprite source and separate back/front 4-pose compositing. POI05 centered on algorithmic segmented SVG chitin repeatedly scaled/spun, giving flat hard outlines, repeated too-small figures and robotic body motion; its QA prioritized green CI and masking artifacts over true appearance. Never reuse R5 flower/giant centipede in later families.
- Owner recommends **gathering faint light strands into a luminous ring** for charge. The new POI06 prototype tests this principle independently; POI05 polish is deferred only because owner instructed moving to next skill.

## POI06 independent art direction
- Visual name: **Hư Giới Vạn Cổ** — original Tu Tiên realm-light, white-hot thin jade cores and violet-green feathered glow. No literal giant worm, spiky icon, heavy dome or shiny HUD donut.
- Signature G0: NINE unequal wisps move inwards at caster's hand, progressively becoming a **broken asymmetrical jade ring** with bright internal hot core. Ring always in front of palm, no face obstruction.
- G1: a compact luminous seed accelerates to a position ABOVE three preview targets. The flight head has a tight jade center, four staggered afterimages, three unequal light fin streaks.
- G2: a dark translucent otherworldly aperture with two layers of **unequal moving curved partial arcs**, in white jade/soft violet, expands in the sky. Center remains sufficiently clear for readable target art; NOT a flat opaque UI ring.
- G3: three distinct thin living light lanes touch three separate target **chest** anchors only. 24 tiny independently animated GU light motes (8 original alpha flipbook frames) follow without pretending to be additional gameplay hits. Three original open/half-rune contamination marks (6 soft SVG frames), 0.18s localized bright contact peak.
- G4: fades through drift into many tiny embers, aperture closes by 5.13s, complete black/no effect after 5.13s, movie loops 5.55s.
- Reference language: approved POI02 softness and Source VL `blend=lighter`; no licensed third-party pixels copied. New original `poison06/assets/abyss_gu_0..7.svg` (transparent 256x256, eight wing poses), `abyss_brand_0..5.svg` (transparent 256x256), code-generated braided halo from 3 layered strokes, origin/destination geometry and native lighting gradients. Uses original TMB valley background for QA consistency.

## Files and exact QA
- `godot/labs/combat_lab/poison06/van_co_phe_gioi.tscn` + `.gd`, created in isolated LAB; `godot/tests/labs/combat_lab/vfx_poi06_contract_test.gd`.
- `.github/workflows/vfx-poi-06-van-co-phe-gioi.yml`: official SHA256-pinned Godot 4.7.2, Stage A restored read-only, strict import & parser, focused GDScript source-contract test, 1280×720 native `--write-movie` 333 frames 60 fixed-step (~5.55s), H.264 MP4/GIF and at least 14 individual frames. Native encoded 60fps is NOT actual Android/Windows GPU 60fps.
- Art QA: inspect t=0.38,0.75,1.06 (charge),1.31/1.71 (flight),2.11/2.38/2.66 (rift),2.98/3.30/3.73 (contact),4.21/4.72/5.20 (fade). Verify ring gathers rather than static circle; outline is light not solid vector; faces & original body costumes stay recognizable, no screen blocking. If it looks like a bland glowy donut, repaint/rework and rerender, not merely increase alpha.
- Currently `ART_BRIEF_READY / CODE_LAB_READY` until exact Godot Actions has finished and actual frames viewed. Never write `GODOT_PASS`/`OWNER_VISUAL_APPROVED` before proof. `PVE_INTEGRATION_HOLD`, `V6.3 OFF`, `PHYSICAL_WINDOWS_ANDROID_PENDING`.
- No rig, no Codex, new branch or merge. Do not touch existing three approved Human Poison LAB source scenes, POI05 archive, Combat V2, SaveService, economy, AI, or catalogs.
