# POI16 R2 — Tam Diệp Linh Dược (Vạn Linh Giải Ách semantic VFX)
Date: 17 Nov 2026. The owner accepted R1E visibility provisionally but rejected **meaningless skill silhouette**. Owner then said to actually make the VFX. R1E is preserved unchanged; this is original new R2 animated artwork, not a promise/prompt or concept-only GIF.

**Gameplay G0 unchanged:** human Dược Độc ultimate = heal, circle radius2.5 world, max3 allied targets, cast1.2s, cooldown46s, range6.5, projectile_speed0, duration0; no real Combat V2 HP receipt.

**Author original true-alpha first-party raster source** `tools/vfx/generate_poi16_semantic_r2.py`: 48 poses, five atlases, five retained source master PNGs at `godot/labs/combat_lab/poison16_van_linh_giai_ach/r2/assets`. 8 seed poses foreshadow 3 herbal buds; 12 three-leaf living medicinal bloomed source frames with clear soft veins, luminous medicine pearl; 10 flowing green/gold stream poses spatially stretched/rotated 3 times from HERB_CORE to 3 separate moving allied chest anchors; 10 short-lived healing-drop two-sprout seals on 3 allies; 8 fade light motes. No unrelated geometric UI rings, generic curtain, black matte, rig or GIF.

**Native Godot** `godot/labs/combat_lab/poison16_van_linh_giai_ach/r2/van_linh_giai_ach_semantic.tscn` renders 3 genuine transforms per frame (links anchored to target), one clear tripetal central medicinal shape, 3 seal cues on separate MOVING allied sprites, fourth moving ally outside/uncued, separate WALK monster unhealed. Visual-only: HP not actually restored. Time seed0–1.2, herb1.2–2.07, links1.39–2.12, seals1.64–2.29, finite fade2.07–2.65. Movie 2.95 s native1280×720/177 encoded frames; this does NOT measure Android FPS. Evidence at .62/1.62/1.92, fade2.42/expired2.80, exact SHA.

**QA G3.5/G3.6/G3.7:** Godot original-asset import + focused contract checks the actual 3 moving target links/seals and status expiry, V4 packet/assets/evidence and unscaled native light visibility. Semantic-shape **G3.7 HUMAN / OWNER** checks whether an observer at 1×, without a label, sees *medicine/herb → 3 transfer channels → 3 healing target seals*. CI cannot approve subjective recognition. Color/tone must remain clear and transparent but not too stiff. No PvE, V6.3, SaveService, rig, branch or merge.

Status: `TECH_QA_PENDING`, `ART_OWNER_PENDING`, `PVE_HOLD`, `V63_OFF`, `PHYSICAL_QA_PENDING`.


### R2B 1× native contrast correction (17/11/2026)
R2 initial Godot at SHA `90df0dd8a78ea761a79d3ac62d0b09ddb2e81958` checked three moving real connections/3 leaves/3 seals: focused technical PASS, but native G3.6 blocked charge268<300, bloom11448<13000, contact10108<14500, fade146<500; expired104<=200. Actual captured video shows clear 3-leaf figure and link locations but insufficient brightness. R2B preserves precisely the semantically meaningful geometry and source 48 poses; increases core/body color saturation, screen size of central herb, flow thickness and individual seals, bright-but-finite jade fade. **Do not lower G3.6 thresholds**; owner semantic G3.7 and visual acceptance still pending. R2 initial source/artifacts retained via exact SHA.


### R2C native-scale occlusion fix after R2B PASS (17/11)
R2B exact SHA `2a122eb75d9ba3b7e5fbc8abcd5ff7705a5bf537`, [Actions #44037236039](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44037236039), G3.6 numerical PASS charge2164/peak16834/contact22131/fade938, expiry88. Human inspection of contact screenshot found **three opaque-looking green recipient stamps covering the character FACES** due to a wrong chest anchor `foot -99px`. R2C corrects chest to `foot -65px`, shrinks front recipient stamp to 84×100 and reduces its front opacity, keeping central three-leaf medicinal silhouette, all three live motion-tracked connections, and original source frame counts. G3.7 face legibility is a mandatory art review criterion; no QA thresholds are relaxed and R2B evidence remains preserved by its exact SHA.


### R2D — final semantic-target contrast and numeric-source QA (17/11)
R2C Godot exact SHA `72437f6b1a89f46ab3cd626209db9f633d254246` was focused PASS but G3.6 contact **13,714<14,500** (charge2164, peak17832, fade1571, expired97 already PASS). Human native inspection confirmed small medicinal seals are much less obstructive than R2B but still touch faces. R2D brightens and slightly broadens only the spatially real transfer streams, lowers torso anchor from foot−65px to foot−56px, leaves original frame count48 and threefold botanical silhouette unchanged. Removes potential invalid fractional power of tiny negative floating-point sine values; retains strict G3.6 visibility requirements and separate manual semantic/owner review.
