# AS-BUILD-01 — Source A building style, direction and visual acceptance

2026-11-11 · PR #72 · ONE GAME Godot 4.7.2 · status: IMAGE CANDIDATE ONLY, IN-GAME PROTOTYPE REJECTED

## Real assets examined (not generic web-style reference)
- Main Hall 510052.png: wide slate layered roof, timber shell, small courtyard, tree and stone.
- Warehouse 510102.png: straw/gray roof, warm wood and sacks/crates.
- Forge 520081.png: muted roof, wood framing and orange fire stack.
- Residence 510076.png: narrow slate roof, wood, plaster, flower garden.
- Guidance 510111.png: curved jade roof with green aura.
- All five PNGs are sourced from godot/art/source_a_env02a/pv01_assets and controlled by map25_source_a_verified.json. Original Source A files remain unchanged; external redistribution rights are not verified.

## Direction count
- These five models have ONE verified intact image region per building. tri_facility_source_a_manifest.json confirms a single atlas region for Hall, Residence and Guidance.
- The code's _iso_two_direction_delta() relates to disciples walking horizontally, NOT building art direction.
- Desired design is two independently rendered isometric 3/4 views with consistent footprint, door and pivot. Do not relabel a mere horizontal mirror as an independently authored second camera angle.

## User rejected look
- The oversized hyper-gold high-fantasy palace was rejected and has not been imported into Godot.
- New target: Source A linework and silhouette, desaturated slate roof + warm peach timber + mild emerald effects, small plants/stone paving, no giant glow halo, no fake resource or animation.

## Actual Godot render-loop evidence
- Baseline: ECO07 run #43056838146, 7 real Linux/Mesa 1280x720 screens, before map style changes.
- Visual candidate: art/reimagined_source_a_v1/alchemy_hall_3q_v1.svg is original procedural code-art inferred from Source A Forge 520081; it is NOT an extracted Alchemy Hall original.
- #43078517282: import/headless+seven screens PASS but zoom 1.0 only drew compact worksite, invalid for detail approval.
- #43079923522: detailed zoom 1.35 on actual canonical BuildingState. Image shows Alchemy candidate overlapping authentic Forge art and actors visually on roof. VISUAL FAIL. No canonical coordinates or saved door cells were altered.
- Remediation at SHA 96ee301e73b96771dd9e77cba41d70ac94cb9c3f: remove Alchemy from live candidate draw map, return to existing safe art/fallback, retain SVG as traceable REVIEW_ONLY candidate. Altered no gameplay, combat, SaveService, Economy, resource stock, wages or policy.

## Generated offline residence style draft
- A two-variant 768x768 transparent PNG pack was generated from a new art master inspired by actual Source A 510076.
- These are only an exploratory visual draft; paired layouts are closely mirrored, not approved distinct rotated perspectives.
- Exported locally in current conversation: TMB_AS_BUILD01_SourceA_style_candidate.zip with per-file SHA-256, pivot metadata and provenance. NOT committed as a runtime building or shipped to clients.

## Next quality gates
1. For Hall 510052 and Residence 510076, create *faithful* render preserving roof silhouette and single original heading; produce an actual separately authored second view (not a flip).
2. At native 174x135/300x201 screen size: inspect transparency, door at correct exterior cell, architecture-to-ground fit and unrelated props/actor occlusion.
3. Capture real Godot screenshot on the same seed/viewport, not a Photoshop composite; compare baseline Source A and new art in identical camera/zoom.
4. Rejected candidates remain staging-only. Promote one building to live renderer only after art visual acceptance + focused 4.7.2 + cumulative screen QA; no bulk replacement.
5. Subsequent missing-source sites (Mine, Forest, Field, Alchemy) are explicitly *inferred new designs*, not actual Source A recreations until matching original IDs and textures are found.

## Release safeguards
- Only PR #72 branch integration/pve-p0-playable-ui-20261103. Draft; no merge.
- Source A originals and SHA registry preserved; other chats own combat/skills. Windows/Android physical visual acceptance PENDING USER.
- Current restored live source at 96ee301e73b96771dd9e77cba41d70ac94cb9c3f needs terminal exact-SHA QA status, not inferred PASS from earlier build.

## AS-BUILD-02 — verified original art gallery & replacement guard (2026-11-12)
- **Source inspection now includes the actual original five PNG sprite images**, not a generic moodboard: Hall 510052 (1104×740 source → 300×201 in-game), Residence 510076 (536×416 → 174×135), Warehouse 510102 (straw/slate roof → 162×138), Forge 520081 (blue slate/furnace → 205×164), Guidance 510111 (jade gate → 182×203). Originals are SHA-checked through the canonical `SectMap25SourceArt` registry.
- Confirmed aesthetic: hand-painted 2.5D brush outlines; irregular grey slate and straw tiles; dusty peach timber/plaster; small crates/trees/grass/stone; restrained mint lights, small warm flames. The earlier hyper-gold palace image and subsequent glossy two-cottage renderings **do not match this source identity** and are NOT accepted runtime art.
- **Directions:** one real camera view each for all five original PNGs, second direction `null` rather than falsely mirroring or misreading the disciple two-direction movement code. This policy now has machine-readable `godot/data/presentation/as_build02_source_a_contract.json` and capture test `godot/tests/presentation/as_build02_source_a_originals_capture.gd`.
- [Real-Godot AS-BUILD-02 run #43160875872](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43160875872) **12/12 steps SUCCESS** on source SHA `7bc70afea94f19a9c07c6c505599176c938173c2`: official 4.7.2 import, strict parse, five original PNG checks, 1280×720 hardware-style viewport screenshot through Linux Mesa/Xvfb. First gallery was **visual FAIL due to native texture overflow** despite earlier test PASS; corrected explicitly with `Sprite2D.scale = in_game_size / source_image_size`, then re-rendered and visually checked. The corrected screenshot contains all five images at their exact in-world display size without clipping.
- This is a **verified baseline/gallery only**. NO replacement building was promoted and nothing modified canonical doors, SaveService, production math or actor occlusion. Existing Source A buildings remain active. Source-A-inspired but absent Mine, Forest, Field, Alchemy should be treated as newly authored roles, separately signed off for origin, actual direction, footprint and native-size visibility.
- **Acceptance debt:** produce independently authored camera-B sprite, preserve door/footprint/alpha/pivot and verify real in-game screenshots at both orientations and multiple zooms. No flipping masquerading as new camera. Windows/Android physical and owner visual approval PENDING.
