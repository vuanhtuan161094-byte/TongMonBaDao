# POI19 R1 — Phụ Cốt Cổ · Tiên B (Phệ Cổ): Liên Cổ Thôn Quang

Date: 2026-11-17, repo `vuanhtuan161094-byte/TongMonBaDao`, Draft PR #72, branch `integration/pve-p0-playable-ui-20261103`. New isolated LAB skill; previous POI18 R2C was **owner provisionally accepted** ("tạm đc") with art polish backlog. Do not silently rewrite POI18 or its original masters.

## G0 — Canonical skill/authority
- `tmb.skill.poison.co_doc.active_01.immortal.b`; tier Tiên, branch Cổ Độc/Phệ Cổ, effect MARK, element WOOD, shape SINGLE_TARGET, radius0, maximum ONE selected enemy, range7.8.
- Cast0.43s, cooldown9.6s, projectile_speed8.96 **world units/s**, mark duration6.5s, no canonical hit_count. `damage_ratio=1.18` and `power=1.12` belong to candidate metadata, **not** independent VFX damage/HP authority. V6.3 OFF.
- Real Combat V2 hit/status/release timestamp UNKNOWN `RUNTIME_MAPPING_PENDING`. VFX cannot create actual damage, poison, heal, or second target effect.

## G1 — Independent first-party motion art
- No copy from Võ Lâm, Kiếm Thế or other copyrighted asset. Preserve rights as original authored, **code-painted** Pillow/NumPy true-transparent RGBA. Prohibited ImageGen poster/collage crop was discarded rather than treated as master art.
- Phệ Cổ is visually distinctive versus POI18 Liên Tâm: a polished single **gold-core jade seed**, five unequal translucent orchid petals, contact petals visibly **FOLDING INWARD** around a moving monster, then a compact glowing orchid seal, representing **hút/khép linh lực**, not damage, AoE, insects or scary body parts. Do not use POI18's butterfly/V-shaped cloth or double-leaf symbol.
- Foreground hot milk-white tiny core + saturated jade-gold material (MIX) + restrained aura/bloom; no vector ring/GIF/rig.

## G2 — The three unrelated clocks
| Layer | Truth / VFX demo |
|---|---|
| Canonical battle | Cast .43s, cooldown 9.6s, one-target mark6.5s, projectile_speed8.96 world-units/s. Actual receipt unknown. |
| Local LAB art | t0–.43 gather; t.43–.55 seed releases; t.55–1.35 jade seed traverses toward independent WALK monster; t1.35 **SIMULATED ONLY** target chest contact; t1.35–2.06 five orchid petals close inward; t1.35–7.85 selected-target orchid mark stays, then fades t7.85–8.10. |
| Demo QA | Initial real Godot G3.5 preflight108 frames=1.8s at fixed60, three native screenshots t.21/.98/1.48; later full8.5s through status expiry only AFTER manual art STOP. Encoder FPS is not measured Android/Windows performance. |

## G3 — Master and atlases
- Code-painted sprite source: `tools/vfx/generate_poi19_phu_cot_co_tien_b_r1.py`. Source imagery not an imagegen or copied commercial asset. First-party illustrated primitives with independently moving five petal curves/veins, seed wake, contact fold and sustained orchid petals; files kept in Git + source master per layer.
- 48 *authored* poses across 4 atlases: gather8×256², traveling seed16×320×256, local fold12×320², small mark12×256². 2× supersampled alpha compositing; independent marks, palette and silhouette; no character rig.
- `godot/labs/combat_lab/poison19_phu_cot_co_tien_b/r1/`: isolated scene and atlas only; accepted Nữ Độc Tu actor texture untouched.

## G3.5–G8 — independent gates
- V4 packet: `docs/operations/vfx_packets/POI19_R1_V4_PREFLIGHT.json`; Godot 4.7.2 GL compatibility strict import and focused independent moving-target/no-forged-receipt tests; exact-SHA native MP4 + 1280×720 PNG G3.5.
- Mandatory manual G3.5/G3.6/G3.7: charge visible at caster, moving seed visible at 1×, petals truly close on **only selected WALK monster**, absence of UI geometric rings, bloom not opaque over monster. A static image or automatic hash/alpha passes do not establish artistic merit.
- First production state: G0/G1/G2/G3 source code candidate committed, G3.5 native `NOT_EXECUTED` until Actions run, G5 full movie `NOT_EXECUTED`; owner art `PENDING`; PvE/V6.3 `HOLD`, physical Windows/Android `PENDING`. Do not merge.

## POI19 R1C final exact-SHA native proof / independent gates — 2026-11-17

- Final tested source SHA: `8b5c236ee7df816b4a2959f24dd892a50e948179`; [Actions run #44060147011](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44060147011): **SUCCESS**. This is the **exact-SHA** that generated video and focused QA; subsequent safe art-archival/docs commits have distinct SHA and do not imply an exact-SHA rerun.
- R1 original source SHA `329979512c0eb2ddaf710995949d34f4f00fdf69` had G3.5 tech PASS but early native 1× review revealed the flying pearl was too small and petals covered the monster's face. R1B source SHA `228ba3eb8ab46f552020d5209503311ba2f7ae75` increased real visible projectile size and moved local fold behind WALK monster. R1C SHA `96a1475286086f97dcd4e0db03b3998ac7cfe18b` moved the persistent orchid mark **above** selected monster and follows its actual moving coordinates. Final proof also adds fixed G3.6 sustain pixel visibility and focused anchor-follow contract.
- G3 48 true-RGBA first-party **code-painted** authored poses, 4 separate committed masters/atlases, no copied cartoon or billboard concept. No ImageGen poster was used; an unrelated wrong-skill generated poster was explicitly DISCARDED.
- G3.5 genuine Godot 4.7.2 Compatibility at 1280×720, capture charge at 0.21s, peak at 0.98s, contact on **independently moving** selected monster at 1.48s. Status acts ONLY as visual LAB simulation: **not** actual Combat V2 receipt.
- G3.6 actual native-specific measured delta bright jade pixels vs t.05 baseline in scene-specific ROIs: **charge+234**, **peak+600**, **contact+379**. Negative-control decoy baseline0 and contact0 (no fake visual spread); success is *minimum 1× visibility*, NOT visual beauty.
- Sustained mark above target head at t2.30=**118** jade pixels, t5.10=**126**, expiring t7.92=**8**, cleared t8.22=**0**. This is G3.6 structural visibility, **not** a live effect-status read/write. Mark follows `mark_anchor_at(t)` with independent WALK movement.
- G4 focused exact-SHA test `POI19_IMMORTAL_MARK_R1_RESULT=PASS failures=0`. No damage, poison status, HP mutation, turn/combat/save changes; target limit1 and 6.5s mark respected on LAB clock.
- G5 genuine Godot native MP4 **1280×720, 60 encoded FPS, 510 frames, 8.5 seconds**, 24 distinct review checkpoints and status-start/mid/expiry/cleared screenshots. **Not** measured Windows/Android device FPS.
- G6 **ART_SELF_POLISH_REQUIRED**. Native-scale legibility and semantic "target folded into orchid/mark" are improved; color purity is good, but the visual still looks a little like a simple game icon: painterly richness/organic floral detail and impact/light material need human polish. Self-evaluation (/5): silhouette3, material3, color4, motion4, contact3, mark visibility4, occlusion4, uniqueness3, fade4. Cannot claim art PASS or owner acceptance.
- G7 V4 evidence manifest shows **technical PASS** and `OWNER_VISUAL_PENDING`; final long movie is independent of actual PvE integration. G8 `PVE_INTEGRATION_HOLD`, `V63_OFF`, `PHYSICAL_WINDOWS_ANDROID_QA_PENDING`; **no merge**. Original POI18 R2C owner-provisional status preserved separately.
