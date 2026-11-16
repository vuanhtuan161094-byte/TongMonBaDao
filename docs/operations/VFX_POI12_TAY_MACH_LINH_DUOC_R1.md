# POI12 — Tẩy Mạch Linh Dược R1 — independent original botanical elixir VFX

**Current source / owner direction:** 2026-11-16, existing PR #72 Draft, integration/pve-p0-playable-ui-20261103. The owner accepted POI11 R9 and directed the next poison skill plus permanent optimized QA V4.1. Older POI11 masters and accepted Poison art are LOCKED; no rig, no Codex, new branch, merge, Combat V2, SaveService, economy, PvE or V6.3 changes.

## G0: exact canonical Human catalogue, NOT inferred from the friendly name

`tmb.skill.poison.duoc_doc.active_01.human` / **Tẩy Mạch Linh Dược** / Dược Độc / Human active / element **wood**, effect **damage**, shape **single_target** cap **1**, cast **0.45s**, cooldown **8.0s**, projectile speed **8**, range **7.5**, damage_ratio **1.35**, radius **0**, duration **0**, stacks **0**. The source **does not** declare hit_count. This skill is NOT a heal and NOT an ongoing poison mark. Do not infer effect from Vietnamese name, poster or visual metaphor. V6.3 OFF; no true hit receipt mapped.

## G1 / G2: separate unique identity

One translucent jade-lime medicinal elixir with warm ivory living highlight and tapering floating botanical filaments. Unlike Độc Châm and the huge purple Vạn Độc burst: this is **one compact fast plant-liquid dart**, not a ring, area burst or lotus. Five visible animation beats: three swirling herb particles converge over the caster palm → single distilled glasslike green droplet forms → one living leaf-tailed dart flies to a LOCKED DEMO moving monster → tiny off-center organic jade-white puncture → narrow residue dissipates, NO poison icon or recovery flash. Use first-party CODE-PAINTED RASTER source, NOT ImageGen painting and NO copied JX/VL commercial pixels. Code painter is a QA candidate only; owner material/shape self-review can REJECT and force replacement with higher-quality painted source.

## G3: source preservation and pose atlas

- Generator: `tools/vfx/generate_poi12_elixir.py` (first-party authored Pillow raster brush, deterministic); permanent source file, not a sticker icon.
- 640×640 transparent PNG first-party source masters `assets/master/poi12_charge_master_640.png`, `poi12_flight_master_640.png`, `poi12_contact_master_640.png`.
- Separate animated RGBA atlases: **8×192² charge; 12×288×160 moving elixir; 10×256² pointed local contact**. 30 distinct code-painted poses, not 30 recorded video frames. Three atlas uncompressed budget ~6.5 MiB; measure actual bytes/QA. Generated alpha masters must be committed after source QA and not replaced with expiring artifact only.
- No character rig and no static identical asset recolored as a different Poison family.

## Three-clock matrix — all contact / target numbers below LAB-only

| Phase | Catalogue or actual receipt | Local visual timeline | Anchor / target following | Confidence |
| --- | --- | --- | --- | --- |
| Charge | cast 0–0.45s | 0–0.45s, 8 painted poses | fixed caster palm (342,426) | canonical cast / synthetic visual |
| Launch / travel | projectile_speed 8 world units; no receipt mapping | 0.45–0.98s, 12 liquid-tail poses | one preselected WALK monster, visual-only interpolation; range in world units NOT validated | RUNTIME_MAPPING_PENDING |
| Contact | target_limit1; damage_ratio1.35; hit_count missing | 0.98s synthetic contact; impact through 1.65s | current monster chest, head remains clear | LAB_SIMULATED_VISUAL_ONLY |
| Fade | no long status / duration0 | 1.40–1.65s dissipates | one target only | no poison badge, no heal |
| QA loop | demo only | 2.30s; G3.5 charge .20 / peak .80 / contact 1.12 | one actually walking fixture and focused moving-anchor test | not game timing |

## G3.5/V4.1 STOP and status

Proposed real native preflight Godot 4.7.2 Compatibility 1280×720 / 86 fixed movie frames; three native images at .20/.80/1.12 on a WALK actor and original master/alpha/pose validation. **G3.5 NOT_EXECUTED until exact-SHA Actions evidence exists.** Then human self-review of actually rendered native 1× art and STOP if generic UI/vector glow, poorly shaped elixir, occlusion, cropping/square halo or weak contact. If it passes human art preflight, only then run compact 132-frame / 2.2s attack-specific movie and >=12 meaningful timestamps. Duration=0 so NO unnecessary 8-second status film. Encoded FPS is NOT physical Windows/Android FPS.

**Strict initial statuses**: `ART_MANUAL_PENDING / OWNER_VISUAL_PENDING / RUNTIME_MAPPING_PENDING / GODOT_TECH_NOT_RUN / PVE_INTEGRATION_HOLD / PHYSICAL_QA_PENDING`. Does not affect previous POI11 R9 acceptance.

## R1 STOP / R2 rebuild — actual Godot evidence (2026-11-16)

- R1 exact CI source `3a8d40cfc2926f3a2cade9fcd52dc3d4db8a4ace` [Actions #43842441646](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43842441646) **TECHNICAL SUCCESS** after pinning Ubuntu 24.04; V4 packet/assets/evidence, Godot strict import/parse/focused and genuine 1280×720 charge/peak/contact on walking target. Artifact #14214061105. Actual native at peak t=.80 looks like a flat green diamond with sparse straight streaks; hit t=1.12 too small and weak. **R1 ART_SELF_STOP / REJECTED, not OWNER APPROVED**; did not execute expensive long clip.
- R2 is a meaningful re-author: curved irregular glass-sap droplet silhouette with per-pixel pigment and liquid veins, brighter painterly white-hot nose and changed elongated tails; larger brighter localized thorn/leaf impact; slight 1× display adjustment. The old R1 masters and atlas remain versioned. All three R2 masters/atlases use separate `_r2.png` names. Must pass fresh Godot G3.5 native 1× self review before movie. R2 remains owner-art PENDING and game disabled.

## R2 G3.5 actual native QA and self art STOP (2026-11-16)

- **R2 exact source** `bb1214707ca2c4319036e73e82422dfb2b4af2fb`; official [GitHub Actions #43843404836](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43843404836) **SUCCESS** technical with Godot 4.7.2 GL Compatibility, strict import/parse, `VFX_POI12_R1_RESULT=PASS failures=0`, three native 1280×720 1× screenshots at .20/.80/1.12 on WALK enemy, original master + atlas V4 integrity checks, 86 fixed video frames. [Artifact #14213154909](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43843404836/artifacts/14213154909). A code-art source, **not** an ImageGen painting; encoded 60fps is not physical hardware performance.
- Original R2 alpha masters and 3 atlas outputs were committed by guarded same-branch CI. **30 sprite poses, 6,537,216 uncompressed RGBA8 bytes ≈6.235 MiB**, excluding actor textures and renderer. G3.5 video is a 1.43 s *QA clip*, not 86 stored sprite pose assets. One moving target is verified, **damage-only**; not an actual Combat V2 hit and not heal.
- Actual 1× native human visual review: R2 removes the clearly geometric R1 green diamond in favor of translucent flowing sap and a larger torso-localized puncture. But at 1280×720 the flying element is still too small, ribbon/leaf material visually thin, and the impact resembles a simple green star. It is **not yet at approved Độc Tu or Lôi Phù painted-material standard**. Critical subjective dimensions: silhouette **3/5**, material/painterly energy **2/5**, light purity **3/5**, stage timing **4/5**, target anchor **4/5**, contact shape **2/5**, identity **3/5**. Art gate **G3.5 SELF ART FAIL / R2 REWORK_REQUIRED** despite technical CI PASS.
- **Process rule applied:** do not export optional 132-frame attack-clip as a quality claim until the actual original hero sprite and contact silhouette meet the human G3.5 threshold. Preserve POI11 R9 owner-approved sources untouched. The next iteration must first improve original painterly art rather than just add random neon/scale to the flat shape.
- **Remaining gates:** `OWNER_VISUAL_PENDING`, `ART_REWORK_REQUIRED`, `RUNTIME_MAPPING_PENDING`, `PVE_INTEGRATION_HOLD`, `V63_OFF`, `PHYSICAL_QA_PENDING`. No new branch, no merge, no Codex, no rig.

## Owner 16/11/2026 — simplified projectile direction instead of four complete skills

Owner explicitly clarified: **"game mình thì cũng k quá là khắc khe đâu. ý là skill phóng đúng hướng là đc."** Requirement is a single projectile atlas pointing to the real target, not four independently drawn skill poses/atlas variants. The POI12 view-only Godot LAB now computes sprite rotation with `projectile_angle(from,to)` for any screen-space direction, draws both original dart and ghost trail in a temporary oriented canvas transform (and resets the transform), and keeps the impact anchored to the moving monster. Focused test covers LEFT/RIGHT/UP/DOWN vector geometry, zero-distance safety and arrival anchor. The actual LAB showcase still depicts one dummy on the right, **not four native-direction scenes**. No changes to character sprite animations, Combat V2, actual target selection or elapsed-event semantics. Artwork R2 remains `OWNER_PROVISIONAL_CONTINUE / ART_REWORK_REQUIRED` until later visual polish; this owner clarification is approval of a simpler direction requirement, not final art approval.

This code and SOP change requires its own exact-SHA Godot preflight; previous R2 Godot success is not QA evidence for the new directional transform.
