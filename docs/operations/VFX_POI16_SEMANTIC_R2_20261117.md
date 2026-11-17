# POI16 R2 — Tam Diệp Linh Dược (Vạn Linh Giải Ách semantic VFX)
Date: 17 Nov 2026. The owner accepted R1E visibility provisionally but rejected **meaningless skill silhouette**. Owner then said to actually make the VFX. R1E is preserved unchanged; this is original new R2 animated artwork, not a promise/prompt or concept-only GIF.

**Gameplay G0 unchanged:** human Dược Độc ultimate = heal, circle radius2.5 world, max3 allied targets, cast1.2s, cooldown46s, range6.5, projectile_speed0, duration0; no real Combat V2 HP receipt.

**Author original true-alpha first-party raster source** `tools/vfx/generate_poi16_semantic_r2.py`: 48 poses, five atlases, five retained source master PNGs at `godot/labs/combat_lab/poison16_van_linh_giai_ach/r2/assets`. 8 seed poses foreshadow 3 herbal buds; 12 three-leaf living medicinal bloomed source frames with clear soft veins, luminous medicine pearl; 10 flowing green/gold stream poses spatially stretched/rotated 3 times from HERB_CORE to 3 separate moving allied chest anchors; 10 short-lived healing-drop two-sprout seals on 3 allies; 8 fade light motes. No unrelated geometric UI rings, generic curtain, black matte, rig or GIF.

**Native Godot** `godot/labs/combat_lab/poison16_van_linh_giai_ach/r2/van_linh_giai_ach_semantic.tscn` renders 3 genuine transforms per frame (links anchored to target), one clear tripetal central medicinal shape, 3 seal cues on separate MOVING allied sprites, fourth moving ally outside/uncued, separate WALK monster unhealed. Visual-only: HP not actually restored. Time seed0–1.2, herb1.2–2.07, links1.39–2.12, seals1.64–2.29, finite fade2.07–2.65. Movie 2.95 s native1280×720/177 encoded frames; this does NOT measure Android FPS. Evidence at .62/1.62/1.92, fade2.42/expired2.80, exact SHA.

**QA G3.5/G3.6/G3.7:** Godot original-asset import + focused contract checks the actual 3 moving target links/seals and status expiry, V4 packet/assets/evidence and unscaled native light visibility. Semantic-shape **G3.7 HUMAN / OWNER** checks whether an observer at 1×, without a label, sees *medicine/herb → 3 transfer channels → 3 healing target seals*. CI cannot approve subjective recognition. Color/tone must remain clear and transparent but not too stiff. No PvE, V6.3, SaveService, rig, branch or merge.

Status: `TECH_QA_PENDING`, `ART_OWNER_PENDING`, `PVE_HOLD`, `V63_OFF`, `PHYSICAL_QA_PENDING`.
