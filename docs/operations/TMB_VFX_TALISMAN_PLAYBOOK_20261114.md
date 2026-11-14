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


## Technical completion register — five Human cast-master LABs, 14 Nov 2026

The owner requested production across the Loî Phù cast family and a caster-underfoot ritual layer. These five LABs now have independent Godot 4.7.2 Compatibility focused test suites plus true 1280×720 fixed-60-frame-clock movies, 14 phase stills and GIF artifacts. **This does NOT constitute five owner-approved art effects, measured device FPS, real Combat V2 hit routing or release readiness.** All five retain `OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD`.

| Skill ID | Current focused art commit | Godot exact-SHA Actions run | QA scope | LAB identity |
|---|---|---|---|---|
| `tmb.skill.talisman.loi_phu.active_01.human` | `58a066a44603d11cccb4fae0f45e7418695aa698` (R6) | [#43579986235](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43579986235) PASS | import, parse, single-target, 12-cell original hero, 2.5D caster ritual, native movie | Charged physical talisman with traveling white-violet filament, single local contact |
| `tmb.skill.talisman.loi_phu.active_02.human` | `26a0e80fa1bdb8c8aec00bf3ed90ad48dd18ca99` (R2) | [#43581036564](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43581036564) PASS | original ten-ink-pose stroke, line cap3, native movie | One jagged thunder calligraphy stroke, limited forks; no physical flying talisman |
| `tmb.skill.talisman.loi_phu.active_03.human` | `095541f957b80add4fd4abee355d7ad8fda03081` (R1) | [#43581636451](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43581636451) PASS | original eight rune-mark poses, 6s single-target marker display, native movie | One persistent seal; **no fake damage or DoT** |
| `tmb.skill.talisman.loi_phu.active_04.human` | `8c7de5d160a2c2de21049e63bbde545df6364cc4` (R2) | [#43582304081](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43582304081) PASS | ten unique cloud-tear poses, line cap2, original fissure, native movie | Single hot tear in soft purple cloud, not TAL02's narrow brush |
| `tmb.skill.talisman.loi_phu.ultimate.human` | `8020aabaac5ea25931217311112e65a445acf650` (R2) | [#43583016438](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43583016438) PASS | ten heavenly rune poses, one dominant sky bolt, line cap3, native movie | Short ritual caster circle, suspended sky talisman and subordinate lateral arcs after demonstration contact |

**Manual visible QA:** TAL01 R6 uses original painted hero plus underfoot array. TAL02 R1 was self-rejected as a rigid neon tube before R2, TAL04 R1 as a flat glowing cloud ribbon before R2, and TAL05 R1 as horizontal almost-straight electric laser before R2. Actual frame stills were inspected at native 1× for each; remaining artistic judgment remains for owner. Do **not** revise the canonical `02_talisman_183.csv` statuses to ART_APPROVED without owner visual approval.

**Next separately scoped work:** request real visual approval for these five Human cast masters; then, only when separately authorized, passive_01..05 / innate receipt-only cues, lineage/tier A/B and divine variants mapped to their exact effect/shape/target cap, and real PvE receipt integration/physical Windows/Android QA. Hardware frame timing remains PENDING. Current release gate is OFF.

