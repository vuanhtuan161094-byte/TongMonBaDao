# PHÙ TU — LÔI PHÙ VFX PLAYBOOK / HUMAN CAST FAMILY — 2026-11-14

## Ownership and visual bible
Owner of `godot/labs/combat_lab/talisman*/**`, dedicated talisman QA and workflows. PR #72 Draft only, same branch. No touching Poison/Fist labs. Source: `godot/data/combat/v63_talisman_combat_catalog.json` and `docs/operations/vfx_school_ledgers/02_talisman_183.csv`, verified live 14 November 2026. 5 Human cast masters (4 active + 1 ultimate), 5 passive proc families + one innate; five tiers/lineages are **not** already art-approved by the Human master.

## Reference to layer mapping
The owner's 14 November screenshot contains seven visual *categories*, not mandatory components in every ability: painted gold/violet talisman, elliptical ground seal, swirling qi band, sparse natural branching lightning, impact crater, thinning purple mist, and rare golden-violet sparks. They are an art-direction reference only. Produce TMB-owned artwork, **do not extract/crop the screenshot and claim it is original licensed gameplay art**.
- **Ground seal**: restrained 2.5D ellipse under caster during charge; 1/3 luminance of the main spell, no UI-style constant ring; place behind feet and fade shortly after release.
- **Air seal**: above the hand or surrounding an authentic prop if choreographically justified; avoid face occlusion.
- **Electrics**: primary white hot line with violet falloff, dynamic branches 0–2, a trailing taper, no 12 uniform solid lines.
- **Contact**: use actual target, shape and event receipts, a split-second peaked light, grounded debris/mist fades with no false damage ticks.
- **Palette**: antique gold `#f9d68a`, violet `#9a67ee`, pale hot white `#fbf7ff`, muted indigo `#241d43`; color hierarchy by intensity rather than hue-only recoloring.

## Human five-cast contract and distinct choreography
| Master / Skill ID suffix | Exact name | Verified mechanic | Proposed identity | Underfoot/other layers |
|---|---|---|---|---|
| `loi_phu.active_01.human` | Điện Quang Khai Phù | damage, lightning, single_target, cap 1, cast 0.50, range 8.5, projectile_speed 10 | 12-pose painted hero talisman, one continuous luminous projectile then short impact | short caster floor-array, narrow air ribbon, one contact crack and sparks |
| `loi_phu.active_02.human` | Thiên Lôi Dẫn Nét | damage, line, cap 3, cast 0.62, range 9.5, projectile_speed 0 | long one-stroke ink lightning drawn outward across declared line, broken line-calligraphy; not another flying projectile | quick calligraphic foot half-seal, fine sweeping ribbon, max 3 confirmed targets |
| `loi_phu.active_03.human` | Lôi Văn Truy Ấn | mark, single_target, cap 1, cast 0.50, range 8.5, duration 6.0 | layered painted magnetic seal locks onto one target, subtle crawling ink | no impact explosion; stamp appears only on verified mark receipt; visible duration follows actual gameplay, not LAB demo clock |
| `loi_phu.active_04.human` | Cửu Tiêu Phá Vân | damage, line, cap 2, cast 0.50, range 9.0 | short violent cleaving thunder sheet, one peak with trailing fork and ragged atmosphere | tight two-stripe ground sign, **two targets maximum** |
| `loi_phu.ultimate.human` | Cửu Thiên Vạn Lôi Phù | damage, line, cap 3, cast 1.05, range 11.0 | monumental open sky rune, central bolt as main focal point and limited side streaks; cinematic but legible | larger but timed ritual circle; 3 legal targets max, no invented AOE or extra hits |

**Passive/innate** `passive_01..05`, `innate.human`: use real proc/receipt only; **no cast demo pretending to be Combat V2**. Higher-tier A/B/rare variants may change shape/target cap; always re-read the exact tier record rather than assume a common Human animation applies.

## Production order + status truth
1. TAL01 Điện Quang Khai Phù: R5 real Godot MP4 produced, owner likes sprite-first *direction* but art not globally signed off. R6 specifically adds supporting ground ring and rhythmic placement, then exact-SHA video/owner inspection.
2. TAL02 Thiên Lôi Dẫn Nét: independent hero brush current, dedicated raster frames and full video; not merely recolored TAL01.
3. TAL03 Lôi Văn Truy Ấn: mark art/receipt distinct from damage contact, no fake 6 second debuff in real battle.
4. TAL04 Cửu Tiêu Phá Vân: compact double-line thunder cut, max 2, distinct staging.
5. TAL05 Cửu Thiên Vạn Lôi Phù: cinematic three-target capped ultimate.

A plan or a catalogue row is **not** an implemented or approved skill. Keep subsequent skills NOT_ART_APPROVED until each has its own art and real Godot visual review. Separate live integration not authorized.
