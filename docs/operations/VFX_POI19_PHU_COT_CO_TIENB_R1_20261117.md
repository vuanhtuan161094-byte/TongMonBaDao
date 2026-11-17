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
